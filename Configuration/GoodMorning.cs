using System;

namespace Configuration
{

    public interface IGreeter
    {
        string Greeting();
    }

    public class GoodMorning : IGreeter
    {

        public string Greeting() => "Good morning!";
    }

    public class GoodEvening : IGreeter
    {

        public string Greeting() => "Good evening!";
    }
}
