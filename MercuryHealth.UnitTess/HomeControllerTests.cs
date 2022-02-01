using NUnit.Framework;
using System.Collections.Generic;
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MercuryHealth.UnitTests;

public class HomeControllerTests
{
    private const string Expected = "Hello World!";

    [SetUp]
    public void Setup()
    {
    }

    [Test]
    public void Test1()
    {
        NUnit.Framework.Assert.Pass();
    }
    [Test]
    public void Test2()
    {
        NUnit.Framework.Assert.Pass();
    }
    [Test]
    public void Test3()
    {
        NUnit.Framework.Assert.Pass();
    }
    [Test]
    public void Test4()
    {
        NUnit.Framework.Assert.Pass();
    }
    [Test]
    public void Test5()
    {
        NUnit.Framework.Assert.Pass();
    }

    [TestMethod]
    public void WriteToTestExplorerWindow()
    {
        Console.WriteLine("Console.WriteLine() now prints to Test Explorer");

        var testStrings = new List<string>();
        testStrings.Add("someString");
        var testString = testStrings.Find(str => str == "someString");
        NUnit.Framework.Assert.IsNotNull(testString);
        NUnit.Framework.Assert.AreEqual(testString, "someString");
    }
}

