### ROConfigurationManager

## Instructions:

- clone this repo inside your app project
- copy it to your project tree on XCode

- In your **viewController.m**:
```
#import "ROConfigurationManager.h"
```
- Run the following commands on your **ViewController.viewDidLoad()**
```
[[ROConfigurationManager configurationManager] setEndpoint:@"YourServerEndPoint"]
``` 
 

## APIs 

```
-(id)ro_valueForKey:(NSString *)key
```

returns the requested, by key, value from configuration

**key** - the key for the value your app needs from configuration

**return** - The value of the key

 ```
 -(void)ro_refetchResponseFromServer;
 ```
refetch the configuration file and cache it.


 
