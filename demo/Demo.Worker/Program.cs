using Demo.Worker;

var builder = Host.CreateApplicationBuilder(args);
builder.Services.AddWindowsService();
builder.Services.AddHostedService<Worker>();
builder.Build().Run();
