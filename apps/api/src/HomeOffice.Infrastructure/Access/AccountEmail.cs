using System.Text.Json;
using HomeOffice.Application.Access;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using MimeKit;
using Microsoft.Extensions.Logging;

namespace HomeOffice.Infrastructure.Access;

public sealed class AccountEmail(IConfiguration config, IHostEnvironment environment, TimeProvider clock, ILogger<AccountEmail> logger) : IAccountEmail
{
    public async Task SendAsync(string email, string purpose, string code)
    {
        if (environment.IsDevelopment() || environment.IsEnvironment("Testing"))
        {
            var folder = config["Email:CaptureDirectory"] ?? Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "HomeOfficeReservation", "email");
            Directory.CreateDirectory(folder);
            if (!OperatingSystem.IsWindows()) File.SetUnixFileMode(folder, UnixFileMode.UserRead | UnixFileMode.UserWrite | UnixFileMode.UserExecute);
            // No HTTP inbox, tokens in query strings, application logging or external delivery in development.
            var path = Path.Combine(folder, $"{clock.GetUtcNow():yyyyMMddHHmmssfff}-{Guid.NewGuid():N}.json");
            await File.WriteAllTextAsync(path, JsonSerializer.Serialize(new { email, purpose, code, issuedAtUtc = clock.GetUtcNow() }));
            if (!OperatingSystem.IsWindows()) File.SetUnixFileMode(path, UnixFileMode.UserRead | UnixFileMode.UserWrite);
            return;
        }
        try
        {
            var message = new MimeMessage();
            message.From.Add(MailboxAddress.Parse(config["Email:From"] ?? throw new InvalidOperationException("SMTP sender must be configured.")));
            message.To.Add(MailboxAddress.Parse(email));
            message.Subject = purpose == "activate" ? "Ativar conta HomeOffice" : "Recuperar acesso HomeOffice";
            message.Body = new TextPart("plain")
            {
                Text = $"Na aplicação HomeOffice, escolha {(purpose == "activate" ? "Ativar conta" : "Repor palavra-passe")} e introduza este código:\n\n{code}\n\nSe não solicitou esta operação, ignore esta mensagem."
            };
            using var smtp = new MailKit.Net.Smtp.SmtpClient();
            await smtp.ConnectAsync(config["Email:Host"]!, config.GetValue("Email:Port", 587), SecureSocketOptions.StartTls);
            await smtp.AuthenticateAsync(config["Email:Username"]!, config["Email:Password"]!);
            await smtp.SendAsync(message);
            await smtp.DisconnectAsync(true);
        }
        catch (Exception)
        {
            // SMTP exception messages can contain recipients. Record no message, token, credentials or recipient.
            logger.LogError("Account email delivery failed. Check the configured SMTP service.");
            throw new EmailDeliveryException();
        }
    }
}
