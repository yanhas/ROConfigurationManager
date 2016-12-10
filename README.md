### ROConfigurationManager

## Instructions:

- clone this repo inside your app project
- Run the following commands on your **ViewController.viewDidLoad()**
```
[[ROConfigurationManager alloc] initWithEndPoint:@"YourServerEndPoint"]
``` 
 

## APIs 

```
-(id)ro_valueForKey:(NSString *)key
```

returns the requested, by key, value from configuration

**key** - the key for the value your app needs from configuration

**return** - The value of the key

 ```
 -(void)refetchResponseFromServer;
 ```
refetch the configuration file and cache it.


 
