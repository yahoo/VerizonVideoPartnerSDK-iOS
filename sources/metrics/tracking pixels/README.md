# Tracking Pixels Code Generation

1. Modify `TrackingPixelsGenerator.swift.erb` with path to YAML file with tracking pixels.
```
path = "your-path-to-tracking-pixels.yaml"
```

This file is located in [here](https://git.ouroath.com/O2/verizon-video-partner-sdk-evolution/blob/master/definitions/tracking%20pixels/tracking-pixels.yaml).

2. Run following command in terminal:

```
erb TrackingPixelsGenerator.swift.erb > TrackingPixelsGenerator.swift   
```

3. Done - `TrackingPixelsGenerator.swift` is updated!