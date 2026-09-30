namespace Demo.Worker;

public class Worker(ILogger<Worker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            logger.LogInformation("{Flavor}: 2 + 3 = {Sum}", Calculator.Flavor, Calculator.Add(2, 3));
            await Task.Delay(1000, stoppingToken);
        }
    }
}
