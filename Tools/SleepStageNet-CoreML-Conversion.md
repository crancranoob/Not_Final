# SleepStageNet Core ML Conversion (for on-device use)

**Target IO**  
- Input: `epochs` – shape `[epochs, channels, samples]` with `channels=3`, `samples=300` (30 s @10 Hz per epoch).  
  Channels: `[ppg_like, rr_like, motion_magnitude]`.  
- Output: `stages` – shape `[epochs]`, int class IDs with mapping: `0=Wake, 1=N1, 2=N2, 3=N3, 4=REM`.

**Recommended architecture**  
- 1D Conv (depth=16, kernel=5, stride=1) + ReLU  
- 1D Conv (depthwise or pointwise) + ReLU (optional)  
- BiLSTM (hidden=64) over time dimension  
- Linear head → 5 classes (softmax)

**Quantization**  
- Prefer **FP16** for simplicity; **8-bit linear** also works (post-training quantization) if accuracy holds.

**Conversion (PyTorch → Core ML)**
```python
import torch, coremltools as ct

class SleepStageNet(torch.nn.Module):
    def __init__(self): ...
    def forward(self, x):  # x: [B, C, T] per epoch or packed [E, C, T]
        ...

model = SleepStageNet().eval()
example = torch.randn(1, 3, 300)  # single epoch
traced = torch.jit.trace(model, example)

mlmodel = ct.convert(
    traced,
    inputs=[ct.TensorType(name="epoch", shape=example.shape)],
    convert_to="mlprogram",
    compute_units=ct.ComputeUnit.ALL,
    minimum_deployment_target=ct.target.iOS16
)
mlmodel.save("SleepStageNet.mlmodel")
```

**Drop-in**  
- Add `SleepStageNet.mlmodel` to the Xcode target; Xcode compiles to `.mlmodelc` at build time.  
- The app will automatically use the Core ML path; otherwise it falls back to the Swift CNN‑LSTM (`SleepStageNetCore`).

**Training data**  
- Open PSG datasets (e.g., MESA, Sleep-EDF) preprocessed into 30 s epochs, aligned HR/RR/motion channels.
- Train with class weighting (N1 under-represented), label smoothing 0.05–0.1, strong augmentation for motion noise.
