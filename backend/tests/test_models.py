import tensorflow as tf

detector_path = "lib/core/models/banknote_detector_pretrained.keras"
detector = tf.keras.models.load_model(detector_path)
print("Detector Input:", detector.input_shape)
print("Detector Output:", detector.output_shape)

multitask_path = "lib/core/models/multitask_banknote_model.keras"
multitask = tf.keras.models.load_model(multitask_path)
print("Multitask Input:", multitask.input_shape)
print("Multitask Output:", multitask.output_shape)
