use settings::Settings;

mod settings;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenvy::dotenv().ok();

    let Settings {
        bind_address,
        rabbitmq,
        database,
        tracing,
    } = Settings::try_new()?;

    let (telemetry, subscriber) = Telemetry::init(make_resource(APP_NAME, env!("CARGO_PKG_VERSION")), tracing)
        .context("Failed to init telemetry")?;
    Telemetry::init_subscriber(subscriber).context("Failed to init telemetry subscriber")?;

    tracing::info!("Starting {APP_NAME} utility...");

    // ...

    telemetry.shutdown();

    Ok(())
}