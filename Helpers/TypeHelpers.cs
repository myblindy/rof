using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

public partial class TypeHelpers : GodotObject
{
    static readonly Dictionary<string, string> sceneToTypeNameCache = new();
    public bool IsInstanceOfType(GodotObject @object, string typeName) => @object is Node node && (sceneToTypeNameCache.TryGetValue(node.SceneFilePath, out var objectTypeName) ? objectTypeName == typeName
        : (sceneToTypeNameCache[node.SceneFilePath] = SceneNameRegex().Match(node.SceneFilePath) is { Success: true } m ? m.Groups[1].Value : null) == typeName);

    [GeneratedRegex("/([^/]*)\\.tscn$")]
    private static partial Regex SceneNameRegex();
}
