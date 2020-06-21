#  DNS
> make DNS query to any DNS sever directly in iOS and MacOS with Swift

## Quick Start
```swift
let ds = DNSService.init()
ds.start()
sleep(1)
ds.query(domain: "vincent178.site", completion: { (rr, err) in
  // Get ip list rr!.Answers.map { $0.RData }
})
```
You can also make dns query to a custom name server
```swift
let ds = DNSService.init(host: "a custom name server")
ds.start()
sleep(1)
ds.query(domain: "vincent178.site", completion: { (rr, err) in
  // Get ip list rr!.Answers.map { $0.RData }
})
```
