```javascript
let options = {
  startDate: (new Date(2016,4,27)).toISOString(), // required
  endDate: (new Date()).toISOString(), // optional; default now
  ascending: false,	// optional; default false
  limit:10, // optional; default no limit
  reason: 'Bolus', // required: Bolus or Basal
};
```

```javascript
AppleHealthKit.getInsulinDeliverySamples(options, (err: Object, results: Array<Object>) => {
  if (err) {
    return;
  }
  console.log(results)
});
```
