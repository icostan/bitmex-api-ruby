# Changelog

 All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
### Changed
- gems update

## [0.1.3] - 2019-07-03
### Changed
- update Ruby to 2.6.3
- update all gems
### Fixed
- query params for filtering in GET requests

## [0.1.2] - 2019-04-17
### Changed
- update gems
### Fixed
- price for limit order spec

## [0.1.1] - 2019-03-06
### Added
- functional state transfer from one websocket block to the next
### Fixed
- topic with multiple symbols issue
- loading ENV vars in bin/console

## [0.1.0] - 2019-02-11
### Added
- authentication via websocket
- idiomatic websocket support for all resources
- license and badge
- examples and APIs endpoints in README
### Changed
- extract REST API implementation into its own class

## [0.0.3] - 2019-01-31
### Added
- Chat, instrument, apikey resources
### Changed
- Trade resource
- Stats, settlement, schema, quote, position resources
- Orderbook, order resources
- Liquidation, leaderboard, insurance, execution, user, announcement
- Make Websocket API interface generic

## [0.0.2] - 2019-01-22
### Added
- Initial Websocket API implementation
- Access private REST API
### Changed
- Account operations

## [0.0.1] - 2019-01-03
### Added
- Basic public REST API support
