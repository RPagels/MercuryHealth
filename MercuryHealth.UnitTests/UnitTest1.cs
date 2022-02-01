using NUnit.Framework;
using System;
using System.Collections.Generic;

namespace MercuryHealth.UnitTests;

public class Tests
{
    private const string Expected = "Hello World!";

    [SetUp]
    public void Setup()
    {
    }

    [Test]
    public void Test1()
    {
        Assert.Pass();
    }

    [Test]
    public void Test2()
    {
        Assert.Pass();
    }

    [Test]
    public void Test3()
    {
        Assert.Pass();
    }

    [Test]
    public void WriteToTestExplorerWindow()
    {
        Console.WriteLine("Console.WriteLine() now prints to Test Explorer");

        var testStrings = new List<string>();
        testStrings.Add("someString");
        var testString = testStrings.Find(str => str == "someString");
        Assert.IsNotNull(testString);
        Assert.AreEqual(testString, "someString");
    }
}
