package com.example.piano_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import java.nio.ByteOrder

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.piano_app/audio"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "generateWaveNative") {
                try {
                    val frequencies = call.argument<List<Double>>("frequencies")!!.toDoubleArray()
                    val duration = call.argument<Double>("duration")!!
                    
                    // C++で波形生成
                    val samples = AudioNative.generateWave(frequencies, duration)
                    
                    // WAVヘッダー作成
                    val wavData = createWavFile(samples, 44100)
                    
                    result.success(wavData)
                } catch (e: Exception) {
                    result.error("NATIVE_ERROR", "Failed to generate audio: ${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
    
    private fun createWavFile(samples: ShortArray, sampleRate: Int): ByteArray {
        val dataSize = samples.size * 2
        val fileSize = 36 + dataSize
        
        val buffer = ByteBuffer.allocate(44 + dataSize).order(ByteOrder.LITTLE_ENDIAN)
        
        // WAVヘッダー
        buffer.put("RIFF".toByteArray())
        buffer.putInt(fileSize)
        buffer.put("WAVE".toByteArray())
        buffer.put("fmt ".toByteArray())
        buffer.putInt(16) // fmt chunk size
        buffer.putShort(1) // audio format (PCM)
        buffer.putShort(2) // channels (stereo)
        buffer.putInt(sampleRate)
        buffer.putInt(sampleRate * 4) // byte rate
        buffer.putShort(4) // block align
        buffer.putShort(16) // bits per sample
        buffer.put("data".toByteArray())
        buffer.putInt(dataSize)
        
        // サンプルデータ
        for (sample in samples) {
            buffer.putShort(sample)
        }
        
        return buffer.array()
    }
}
