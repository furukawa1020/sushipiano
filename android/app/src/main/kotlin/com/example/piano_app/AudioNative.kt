package com.example.piano_app

object AudioNative {
    init {
        System.loadLibrary("audio_native")
    }
    
    external fun generateWave(frequencies: DoubleArray, duration: Double): ShortArray
}
