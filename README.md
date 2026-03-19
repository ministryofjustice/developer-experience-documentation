# Developer Experience Documentation

This repository contains the Ministry of Justice Developer Experience documentation site, built with the Government Digital Service [tech-docs-gem](https://github.com/alphagov/tech-docs-gem).

It is the home for guidance on:

- getting started with this documentation site
- writing and reviewing documentation consistently
- publishing and maintaining high-quality technical content
- repository structure and contribution workflow

## Core team repositories

- [ministryofjustice/ministry-of-justice-developer-experience](https://github.com/ministryofjustice/ministry-of-justice-developer-experience)
- [ministryofjustice/moj-github-discovery](https://github.com/ministryofjustice/moj-github-discovery)

## Documentation structure

The primary docs are in `source/` and organised by topic, including:

- `get_started/`
- `working_with_docs/`
- `delivery/`
- `reference/`
- `support/`

Historical GDS Technical Documentation Template content is retained in `source/legacy-tdt-documentation/` for reference.

## Developing locally

### Requirements

- Docker

### Preview the site

Run the site locally (available at <http://127.0.0.1:4567>):

```bash
make preview
```

### Build the site package

```bash
make package
```

### Check links

This repo uses [Lychee](https://github.com/lycheeverse/lychee) in CI. To run link checks locally:

```bash
make link-check
```

## Publishing

The GitHub Actions workflow in `.github/workflows/publish.yml` publishes to GitHub Pages when changes are merged to `main`.
