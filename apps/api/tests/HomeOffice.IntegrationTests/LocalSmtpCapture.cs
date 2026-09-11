using System.Collections.Concurrent;
using System.Net;
using System.Net.Sockets;
using System.Text;
using MimeKit;

namespace HomeOffice.IntegrationTests;

// A loopback-only SMTP peer: exercises the real MailKit adapter, not an IAccountEmail mock.
internal sealed class LocalSmtpCapture : IAsyncDisposable
{
    private readonly TcpListener listener = new(IPAddress.Loopback, 0);
    private readonly CancellationTokenSource stop = new();
    private readonly Task server;
    public bool Reject { get; set; }
    public bool LoseAcknowledgement { get; set; }
    public ConcurrentQueue<MimeMessage> Messages { get; } = new();
    public int Port => ((IPEndPoint)listener.LocalEndpoint).Port;
    public LocalSmtpCapture() { listener.Start(); server = Run(); }
    private async Task Run()
    {
        try
        {
            while (!stop.IsCancellationRequested)
            {
                using var client = await listener.AcceptTcpClientAsync(stop.Token);
                await using var stream = client.GetStream();
                using var reader = new StreamReader(stream, Encoding.UTF8, leaveOpen: true);
                await using var writer = new StreamWriter(stream, new UTF8Encoding(false), leaveOpen: true) { NewLine = "\r\n", AutoFlush = true };
                await writer.WriteLineAsync("220 local synthetic capture");
                while (await reader.ReadLineAsync(stop.Token) is { } line)
                {
                    var verb = line.Split(' ')[0].ToUpperInvariant();
                    if (verb is "EHLO" or "HELO") await writer.WriteLineAsync("250 local.test");
                    else if (verb == "DATA")
                    {
                        await writer.WriteLineAsync("354 End with dot");
                        var text = new StringBuilder();
                        while (await reader.ReadLineAsync(stop.Token) is { } body && body != ".")
                            text.Append(body.StartsWith("..", StringComparison.Ordinal) ? body[1..] : body).Append("\r\n");
                        if (Reject) { await writer.WriteLineAsync("451 Synthetic unavailable"); continue; }
                        using var bytes = new MemoryStream(Encoding.UTF8.GetBytes(text.ToString()));
                        Messages.Enqueue(await MimeMessage.LoadAsync(bytes, stop.Token));
                        if (LoseAcknowledgement) break;
                        await writer.WriteLineAsync("250 Captured locally");
                    }
                    else if (verb == "QUIT") { await writer.WriteLineAsync("221 Bye"); break; }
                    else await writer.WriteLineAsync("250 OK");
                }
            }
        }
        catch (OperationCanceledException) when (stop.IsCancellationRequested) { }
    }
    public async ValueTask DisposeAsync()
    {
        await stop.CancelAsync(); listener.Stop(); await server; stop.Dispose();
    }
}
