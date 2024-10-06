use std::sync::RwLock;

use flutter_rust_bridge::frb;

use crate::frb_generated::StreamSink;


static LOGGER: RwLock<Option<StreamSink<String>>> = RwLock::new(None);

/// initialize a stream to pass log events to dart/flutter
pub fn init_rust_logger(sink: StreamSink<String>) {
    let mut logger = match LOGGER.write() {
        Ok(val) => val,
        Err(val) => val.into_inner(),
    };
    *logger = Some(sink);
}

#[frb(ignore)]
pub fn log_to_dart(msg: String) {
    let logger = match LOGGER.read() {
        Ok(val) => val,
        Err(val) => val.into_inner(),
    };
    if let Some(logger) = logger.as_ref() {
        let _ = logger.add(msg);
    }
}