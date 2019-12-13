```javascript
let options = {
  startDate: (new Date(2016,4,27)).toISOString(), // required
  reason: "Bolus", // required; Bolus or Basal
  value: 0.801
};
```

```javascript
AppleHealthKit.saveInsulinDelivery(options, (err: Object, results: Array<Object>) => {
  if (err) {
    return;
  }
  console.log(results)
});
```
