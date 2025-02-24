# Solidus PayPal Marketplace

[![CircleCI](https://circleci.com/gh/solidusio-contrib/solidus_paypal_marketplace.svg?style=shield)](https://circleci.com/gh/solidusio-contrib/solidus_paypal_marketplace)
[![codecov](https://codecov.io/gh/solidusio-contrib/solidus_paypal_marketplace/branch/main/graph/badge.svg?token=ywAGAmYt9W)](https://codecov.io/gh/solidusio-contrib/solidus_paypal_marketplace)

Solidus PayPal Marketplace is a Solidus extension that provides one possible implementation of a marketplace using Solidus and PayPal Commerce Platform as payment method (via the [solidus_paypal_commerce_platform extension](https://github.com/solidusio-contrib/solidus_paypal_commerce_platform)). 

[PayPal Commerce Platform](https://www.paypal.com/business/platforms-and-marketplaces) has a lot of built-in features specific for marketplaces and this extension take advantage of them to design a simple marketplace architecture.

- Admin users will be able to create sellers and initiate their onboarding flow.
- Sellers will receive the onboarding email and will be able to login and connect their seller account with their business PayPal account.
- Once seller account is properly configured, they can manage their catalogue availability, prices, even via uploading a .csv file.
- Sellers can manage their shipments, by accepting, rejecting or marking them as shipped.
- Sellers will receive payoffs for their orders on their PayPal account directly.

## Installation

Add solidus_paypal_marketplace to your Gemfile:

```ruby
gem 'solidus_paypal_marketplace'
```

Bundle your dependencies and run the installation generator, then seed the database:

```shell
bin/rails generate solidus_paypal_marketplace:install
bin/rails solidus_paypal_marketplace:db:seed
```

## Requirements

You will need an approved PayPal Platform Partner app.
Some webhooks are needed to be enabled for the extension to work properly.

Log in in your PayPal business account and edit your app.
At the bottom of the form press the `Add Webhook` button.
In the `Webhook URL field` insert the domain of your application, followed by `/paypal_webhooks` (eg: `https://myapp.com/paypal_webhooks`).
Select the following events from the checkboxes list and save.

Merchant onboarding completed
Merchant partner-consent revoked
Payment capture completed
Payment capture denied

This will create a `Webhook Id` to be used in the configuration below, along with the app `Client ID`, `Secret` and `Partner Code`.

## Usage

Configure it with:

```
# config/initializer/solidus_paypal_marketplace.rb

SolidusPaypalMarketplace.configure do |config|
  config.paypal_client_id = ENV.fetch('PAYPAL_CLIENT_ID')
  config.paypal_client_secret = ENV.fetch('PAYPAL_CLIENT_SECRET')
  config.partner_code = ENV.fetch('PAYPAL_PARTNER_CODE')
  config.paypal_partner_id = ENV.fetch('PAYPAL_PARTNER_ID')
  config.paypal_webhook_id = ENV.fetch('PAYPAL_WEBHOOK_ID')
end
```

`PayPal Partner Id` and `PayPal Client Secret` can be found in the details of your approved partner app.

`PayPal Partner Code` will be given to you on marketplace approval from PayPal.

`PayPal Partner Id` is the `Account ID` found in the details of your PayPal approved partner account.

`PayPal Webhook Id` will be found on the bottom of your approved partner app details.

Then go to the "Settings/Payments" section and click the "New Payment Method" button. Select `PayPal Marlketplace Platform` as payment type. After creation, set the credentials by selecting `paypal_marketplace_credentials` as "Preference Source".

Sellers can be created in the "Sellers" section, a individual `percentage` value must be set in order to calulate the platform fee for each purchase.
Click on the "Start Onboarding" button on the newly created seller to generate the `action_url` needed to perform his onboarding. This can be refreshed at any time if needed.

Seller will be guided in the onboarding process on first login.
To do that, be sure to create at least a user for each seller. The user will need to have the "seller" role and a seller selected from the dropdown menu.

After user creation, seller will be notified of the possibility to login on the platform.
The only action possible at this moment will be clicking a link to connect his PayPal Account. This will open a PayPal popup where insert PayPal credentials can be inserted or a new account can be created.
When this is done, seller's status will be updated from `pending` either to `accepted` or `rejected`.
According to this will or not be able to use the platfform.


## Development

Step to test the seller onboarding process using localtunnel.

1) npm install -g localtunnel
2) lt --port 3000
3) Visit the tunneled link
4) As Admin, visit the admin seller edit page
5) Click on top right `Start Onboarding`
6) Switch to seller user
7) Click on `link PayPal account`

### Testing the extension

First bundle your dependencies, then run `bin/rake`. `bin/rake` will default to building the dummy
app if it does not exist, then it will run specs. The dummy app can be regenerated by using
`bin/rake extension:test_app`.

```shell
bin/rake
```

To run [Rubocop](https://github.com/bbatsov/rubocop) static code analysis run

```shell
bundle exec rubocop
```

When testing your application's integration with this extension you may use its factories.
Simply add this require statement to your spec_helper:

```ruby
require 'solidus_paypal_marketplace/factories'
```

### Running the sandbox

To run this extension in a sandboxed Solidus application, you can run `bin/sandbox`. The path for
the sandbox app is `./sandbox` and `bin/rails` will forward any Rails commands to
`sandbox/bin/rails`.

Here's an example:

```
$ bin/rails server
=> Booting Puma
=> Rails 6.0.2.1 application starting in development
* Listening on tcp://127.0.0.1:3000
Use Ctrl-C to stop
```

### Preserving the seeds
Seeds loader will search for a `DEFAULT_MERCHANT_ID` and `DEFAULT_MERCHANT_ID_IN_PAYPAL` env variables to load in the default seller,
or even for an array of sellers data inside a `SELLER_SEEDS` env variable (this should be JSON encoded).
This can help preserving sellers across sandbox resets.
```
# Default data

DEFAULT_MERCHANT_ID=00000000-0000-0000-0000-000000000000
DEFAULT_MERCHANT_ID_IN_PAYPAL=XXXXXXXXXXXXX

# Custom data
# NB: Seller JSON data is easy obtainable with a query like
# `Spree::Seller.select(:name, :percentage, :merchant_id, :merchant_id_in_paypal).to_json`

SELLER_SEEDS="[{\"name\":\"Seller A\",\"percentage\":10.0,\"merchant_id\":\"11111111-1111-1111-1111-111111111111\",\"merchant_id_in_paypal\":\"AAAAAAAAAAAAA\"},{\"name\":\"Seller B\",\"percentage\":20.0,\"merchant_id\":null,\"merchant_id_in_paypal\":null\}]"
```

### Updating the changelog

Before and after releases the changelog should be updated to reflect the up-to-date status of
the project:

```shell
bin/rake changelog
git add CHANGELOG.md
git commit -m "Update the changelog"
```

### Releasing new versions

Please refer to the dedicated [page](https://github.com/solidusio/solidus/wiki/How-to-release-extensions) on Solidus wiki.

## License

Copyright (c) 2021 Nebulab, released under the New BSD License
