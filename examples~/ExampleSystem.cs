using Newtonsoft.Json.Linq;
using Unity.Collections;
using Unity.Entities;
using UnityEngine;
using System;
using System.Linq;

public partial class Example : SystemBase
{

        //Note this string is public static, so it can be tested by Unit tests. 
        //Also it doesn't involve any ECS concepts, just operating on data that gets passed in.
        //It has no state.
        public static bool IsGreaterThanZero(int value)
        {
            return value > 0;
        }
    }
    protected override void OnCreate()
    {
        //This function happens once no matter what
        //But it also happens very early. So if you need to access other systems, use OnStartRunning() instead

        //Only bother updating if there are kings to crown
        //This is usually not necessary, but useful for making assumptions about Singletons existing
        RequireForUpdate<King>();

        //Systems are auto-created and enabled by default, but you could also turn it off
        //this.Enabled = false;
    }

    protected override void OnStartRunning()
    {
        //This runs whenever a system about to update after having been newly enabled or re-enabled
        //This is where you would do any one-time initialization that relies of external things.
    }

    //An internal flag we can use to keep track of what we've already looked at or worked on
    struct Flag : IComponentData { }

    protected override void OnUpdate()
    {
        using EntityCommandBuffer ecb = new EntityCommandBuffer(Allocator.TempJob);
        foreach (var (item, entity) in SystemAPI
            .Query<King>()
            .WithAll<IsAlive>()
            .WithNone<Crown>()
            .WithEntityAccess())
        {

            ecb.AddComponent(entity, new Crown());
        }

        ecb.Playback(EntityManager);
    }
}