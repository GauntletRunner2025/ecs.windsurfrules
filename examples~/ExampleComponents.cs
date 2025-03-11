using Unity.Entities;

//This is a tag component, it has no fields but its presence on an entity conveys some inforation.
public struct IsAlive : IComponentData { }

//Note this has only one field, named Value
//Components can have either one, or none fields.
public struct Age : IComponentData {
    public int Value;
}

public struct King : IComponentData { }
public struct Crown : IComponentData { }