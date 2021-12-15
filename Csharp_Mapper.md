# C# Mapper

## Match C# class properties by name

This method provides a simple way to convert one type to another type, matching the differenty properties on names.

It serializes the Source data to a JSON object. Because JSON doesn't have a "type", you can then deserialize the JSON to the desired output type. Any properties with matching names and types will convert. 

```
static public class Mapper
{
    //Take the source data, convert to JSON. Convert the json to the destination class.
    static public T1 Convert<T, T1>(T source)
    {
        JsonSerializerSettings settings = new JsonSerializerSettings() { ReferenceLoopHandling = ReferenceLoopHandling.Ignore };
        var json = JsonConvert.SerializeObject(source, settings);
        T1 result = JsonConvert.DeserializeObject<T1>(json);
        return result;
    }
}
```
