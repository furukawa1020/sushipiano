#ifndef AUDIO_GENERATOR_H
#define AUDIO_GENERATOR_H

#include <jni.h>
#include <cmath>
#include <vector>
#include <algorithm>

class AudioGenerator {
public:
    // 高速波形生成（SIMD最適化可能）
    static std::vector<int16_t> generateWaveform(
        const std::vector<double>& frequencies,
        double duration,
        int sampleRate = 44100
    );
    
private:
    static inline double fastSin(double x);
    static inline int16_t clampSample(double value);
};

#endif // AUDIO_GENERATOR_H
