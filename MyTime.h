#ifndef MYTIME_H
#define MYTIME_H

#include <stdio.h>
#include <sys/time.h>

class MyTime
{
private:
    struct timeval _t;

public:
    MyTime()
    {
        init();
    }

    inline void init()
    {
        gettimeofday(&_t, NULL);
    }

    inline double now(const char *key = NULL)
    {
        struct timeval _n;
        gettimeofday(&_n, NULL);
        double duration = (1000000 * (_n.tv_sec - _t.tv_sec) + _n.tv_usec - _t.tv_usec) / 1000.0;

        if(key)
        {
            printf("%s time cost is: %f ms\n", key, duration);
        }

        return duration;
    }

    inline double reset(const char *key = NULL)
    {
        double duration = now();
        init();

        if(key)
        {
            printf("%s time cost is: %f ms\n", key, duration);
        }

        return duration;
    }
};

#endif //MYTIME_H

