using Unity.Entities;
using UnityEngine;

namespace GauntletRunner.Hackathon
{
    [UpdateInGroup(typeof(InitializationSystemGroup))]
    public partial class FrameRateManagerSystem : SystemBase
    {
        protected override void OnStartRunning()
        {
            Application.targetFrameRate = 10;
        }

        protected override void OnUpdate()
        {
            // System doesn't need to do anything during update
        }
    }
}
