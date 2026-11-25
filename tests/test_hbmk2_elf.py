"""Bounded native adapter validation never executes unvalidated output."""
from pathlib import Path
import importlib.util,struct,tempfile,unittest
p=Path(__file__).resolve().parents[1]/'tools/hbc_hbmk2.py'
spec=importlib.util.spec_from_file_location('adapter_elf',p)
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)

def image():
    data=bytearray(256)
    data[:7]=b'\x7fELF\x02\x01\x01'
    struct.pack_into('<HHIQQQIHHHHHH',data,16,2,62,1,0x400080,64,0,0,64,56,1,0,0,0)
    struct.pack_into('<IIQQQQQQ',data,64,1,5,0,0x400000,0,256,256,4096)
    return data

class ElfContract(unittest.TestCase):
    def setUp(self):
        self.t=tempfile.TemporaryDirectory();self.addCleanup(self.t.cleanup)
        self.path=Path(self.t.name)/'output'
    def validate(self,data):self.path.write_bytes(data);m.validate_native_elf(self.path)
    def test_static_executable(self):self.validate(image())
    def test_short_header(self):
        for n in [0,5,63]:
            with self.subTest(n=n),self.assertRaises(ValueError):self.validate(image()[:n])
    def test_header_fields(self):
        for offset,fmt,value in [(0,'B',0),(4,'B',1),(5,'B',2),(6,'B',0),(16,'H',3),(18,'H',183),(20,'I',0),(52,'H',0),(54,'H',0),(56,'H',0),(32,'Q',240),(24,'Q',0x400100)]:
            data=image();struct.pack_into('<'+fmt,data,offset,value)
            with self.subTest(offset=offset),self.assertRaises(ValueError):self.validate(data)
    def test_segment_fields(self):
        for offset,fmt,value in [(64,'I',2),(64,'I',3),(64,'I',0),(68,'I',4),(96,'Q',257),(104,'Q',255),(112,'Q',3),(80,'Q',0xfffffffffffffff0)]:
            data=image();struct.pack_into('<'+fmt,data,offset,value)
            with self.subTest(offset=offset),self.assertRaises(ValueError):self.validate(data)
    def test_entry_in_bss_is_not_executable(self):
        data=image();struct.pack_into('<Q',data,96,128)
        with self.assertRaises(ValueError):self.validate(data)
