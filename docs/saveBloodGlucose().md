save a blood glucose value to Healthkit

```javascript
let options = {
  value: 120.6, // mg/dL
  startDate: (new Date(2019, 6, 2, 6, 0, 0)).toISOString()
}
```

```javascript
AppleHealthKit.saveBloodGlucose(options: Object, (err: Object, results: Object) => {
    if (err) {
        console.log("error saving blood glucose sample to Healthkit: ", err);
        return;
    }
    // Done
});
```
