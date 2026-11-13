// conditional compilation selects the branch at preprocess time
#define DEBUG
function main()
#ifdef DEBUG
    ? 1
#else
    ? 2
#endif
    return nil
