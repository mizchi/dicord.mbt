///|
pub struct API {
  channels : ChannelsAPI
  interactions : InteractionsAPI
  webhooks : WebhooksAPI
  users : UsersAPI
  guilds : GuildsAPI
  voice : VoiceAPI
}

///|
pub fn API::new(rest : RestClient) -> API {
  {
    channels: ChannelsAPI::new(rest),
    interactions: InteractionsAPI::new(rest),
    webhooks: WebhooksAPI::new(rest),
    users: UsersAPI::new(rest),
    guilds: GuildsAPI::new(rest),
    voice: VoiceAPI::new(rest),
  }
}
