use rust_utils::{impl_settings, telemetry::TracingSettings, db::DbSettings};

static APP_ENV_PREFIX: &str = "{{ env_prefix | upcase }}";
pub static APP_NAME: &str = env!("CARGO_PKG_NAME");

impl_settings! {
     #[derive(Deserialize, Eq, PartialEq, Debug)]
     pub struct Settings {
          #[serde(default = "Settings::default_bind_address")]
          pub bind_address: String => String::from("0.0.0.0:8000")
          #[serde(default)]
          pub rabbitmq: RabbitMQSettings => RabbitMQSettings::default(),
          #[serde(default)]
          pub database: DbSettings => DbSettings::default(),
          #[serde(default)]
          pub tracing: TracingSettings => TracingSettings::default(),
     }
}