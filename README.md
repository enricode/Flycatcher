# Flycatcher
Flycatcher is an asyncronus image loader with caching written in Swift.

**This sofware is still in development, feel free to contribute**

## How it works
### Using manager for load

```
let manager = Flycatcher.downloader()
manager.load("http://www.example.com/happy_image.jpg", completion: { result in
  let image = UIImage(data: result.resource.resourceData!)
  // do whatever you want
})
```

### Using UIImageView extension

```
let imageView = UIImageView
imageView.setAsyncImage("http://www.example.com/happy_image.jpg")
```

### Using manager for preload
```
let manager = Flycatcher.downloader()
manager.preload(
  [
    "http://www.example.com/happy_image.jpg",
    "http://www.example.com/sad_image.jpg",
    "http://www.example.com/angry_image.jpg"
  ]
)

...
// the image is already cached
imageView.setAsyncImage("http://www.example.com/happy_image.jpg")

```
