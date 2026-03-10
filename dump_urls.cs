using MongoDB.Driver;
using System;
using System.Linq;

var client = new MongoClient("mongodb+srv://isaiassynthesis35_db_user:PredadorXR001@cluster0.jvzqseh.mongodb.net/kiosco_db?appName=Cluster0");
var database = client.GetDatabase("kiosco_db");
var projects = database.GetCollection<MongoDB.Bson.BsonDocument>("Projects");

var list = projects.Find(new MongoDB.Bson.BsonDocument()).ToList();
foreach (var p in list)
{
    Console.WriteLine($"Project: {p["title"]}");
    if (p.Contains("coverImageUrl")) Console.WriteLine($"  Cover: {p["coverImageUrl"]}");
    if (p.Contains("iconUrl")) Console.WriteLine($"  Icon: {p["iconUrl"]}");
    if (p.Contains("galleryUrls")) {
        foreach (var u in p["galleryUrls"].AsBsonArray) Console.WriteLine($"  Gallery: {u}");
    }
}
