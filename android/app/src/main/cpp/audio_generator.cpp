#include "audio_generator.h"
#include <cstring>

// 高速sin近似（Taylor展開）
inline double AudioGenerator::fastSin(double x) {
    // 範囲を-π～πに正規化
    while (x > M_PI) x -= 2 * M_PI;
    while (x < -M_PI) x += 2 * M_PI;
    
    // Taylor展開（5次まで、高精度）
    double x2 = x * x;
    return x * (1.0 - x2 * (1.0/6.0 - x2 * (1.0/120.0 - x2/5040.0)));
}

// サンプル値クランプ
inline int16_t AudioGenerator::clampSample(double value) {
    if (value > 32767.0) return 32767;
    if (value < -32767.0) return -32767;
    return static_cast<int16_t>(value);
}

// 最適化された波形生成
std::vector<int16_t> AudioGenerator::generateWaveform(
    const std::vector<double>& frequencies,
    double duration,
    int sampleRate
) {
    const int samples = static_cast<int>(sampleRate * duration);
    std::vector<int16_t> audioData;
    audioData.reserve(samples * 2); // ステレオ
    
    const double dt = 1.0 / sampleRate;
    const double volumeNorm = 1.0 / std::sqrt(static_cast<double>(frequencies.size()));
    
    // エンベロープパラメータ（事前計算）
    const double attackTime = std::min(0.03, duration * 0.02);
    const double decayTime = std::min(0.10, duration * 0.06);
    const double sustainLevel = 0.85;
    const double releaseTime = std::min(0.3, duration * 0.15);
    const double sustainStart = attackTime + decayTime;
    const double releaseStart = duration - releaseTime;
    
    for (int i = 0; i < samples; ++i) {
        double time = i * dt;
        double mixedWave = 0.0;
        
        // 全周波数の合成
        for (size_t f = 0; f < frequencies.size(); ++f) {
            double freq = frequencies[f];
            double phase = 2.0 * M_PI * freq * time;
            
            // 基音 + 倍音（5倍音まで）
            mixedWave += fastSin(phase) * 0.6;
            mixedWave += fastSin(phase * 2.0) * 0.2;
            mixedWave += fastSin(phase * 3.0) * 0.12;
            mixedWave += fastSin(phase * 4.0) * 0.06;
            mixedWave += fastSin(phase * 5.0) * 0.03;
        }
        
        mixedWave *= volumeNorm;
        
        // ADSRエンベロープ（高速分岐）
        double envelope;
        if (time < attackTime) {
            envelope = time / attackTime;
        } else if (time < sustainStart) {
            envelope = 1.0 - (time - attackTime) / decayTime * (1.0 - sustainLevel);
        } else if (time < releaseStart) {
            envelope = sustainLevel;
        } else {
            envelope = sustainLevel * (1.0 - (time - releaseStart) / releaseTime);
        }
        
        // 長音の音量ブースト
        if (duration > 2.0) envelope *= 1.2;
        
        mixedWave *= envelope;
        
        // ソフトクリッピング
        if (mixedWave > 0.8) {
            mixedWave = 0.8 + (mixedWave - 0.8) * 0.3;
        } else if (mixedWave < -0.8) {
            mixedWave = -0.8 + (mixedWave + 0.8) * 0.3;
        }
        
        mixedWave *= 0.9;
        
        // 16bit整数に変換（ステレオ）
        int16_t sample = clampSample(mixedWave * 32767.0);
        audioData.push_back(sample); // L
        audioData.push_back(sample); // R
    }
    
    return audioData;
}

// JNI接続
extern "C" JNIEXPORT jshortArray JNICALL
Java_com_example_piano_1app_AudioNative_generateWave(
    JNIEnv* env,
    jobject /* this */,
    jdoubleArray freqArray,
    jdouble duration
) {
    // Java配列をC++に変換
    jsize len = env->GetArrayLength(freqArray);
    jdouble* freqs = env->GetDoubleArrayElements(freqArray, nullptr);
    
    std::vector<double> frequencies(freqs, freqs + len);
    env->ReleaseDoubleArrayElements(freqArray, freqs, 0);
    
    // 波形生成
    std::vector<int16_t> waveform = AudioGenerator::generateWaveform(frequencies, duration);
    
    // Java配列に変換して返す
    jshortArray result = env->NewShortArray(waveform.size());
    env->SetShortArrayRegion(result, 0, waveform.size(), waveform.data());
    
    return result;
}
