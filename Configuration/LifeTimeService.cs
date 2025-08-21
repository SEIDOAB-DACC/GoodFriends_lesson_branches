using System;

namespace Configuration
{
    public class LifeTimeService
    {
        private readonly Guid _guid;

        public LifeTimeService()
        {
            _guid = Guid.NewGuid();
        }

        public Guid GetGuid()
        {
            return _guid;
        }
    }
}
