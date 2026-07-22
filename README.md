# open_cart_test

Lokalni OpenCart 4 demo webshop koji se pokreće u Dockeru, automatski instaliran uz demo podatke (MacBook, iPhone, Apple Cinema 30" itd.).

## Pokretanje

```bash
docker compose up -d --build
```

Prvo pokretanje traje malo dulje jer se preuzima OpenCart i instalira baza. Prati napredak s:

```bash
docker compose logs -f opencart
```

Kad u logu piše `SUCCESS! OpenCart successfully installed`, shop je spreman.

## Pristup

Portovi se mogu prilagoditi u `.env` (npr. ako su 8080/8081 već zauzeti drugim kontejnerima).

| Servis          | URL                             | Podaci za prijavu              |
|-----------------|----------------------------------|---------------------------------|
| Prodavaonica    | http://localhost:8083/          | —                                |
| Admin panel     | http://localhost:8083/admin/    | `admin` / `admin123`             |
| Adminer (baza)  | http://localhost:8084/          | server `db`, `opencart`/`opencart`|

Sve podatke za prijavu i portove možeš promijeniti u `.env` prije prvog pokretanja (`docker compose up`).

## Struktura

- `docker-compose.yml` — MariaDB + OpenCart (PHP/Apache) + Adminer
- `docker/opencart/Dockerfile` — preuzima i gradi OpenCart (verzija podesiva preko `OPENCART_VERSION` u `.env`)
- `docker/opencart/entrypoint.sh` — pri prvom pokretanju čeka bazu i pokreće OpenCart-ov CLI installer (`install/cli_install.php`), pa uklanja `install/` direktorij

Podaci (baza + OpenCart datoteke) žive u Docker volumenima (`db_data`, `opencart_data`), pa ostaju sačuvani i nakon `docker compose down` (ali ne i nakon `docker compose down -v`).

## Zaustavljanje / reset

```bash
docker compose down        # zaustavi, zadrži podatke
docker compose down -v      # zaustavi i obriši sve podatke (svježa instalacija idući put)
```

## Produkcijsko pokretanje (iza Traefika)

Za pokretanje na serveru koji ima Traefik reverse proxy (Docker mreža `traefik`), koristi `docker-compose.prod.yml`. Ovaj oblik ne objavljuje portove izravno na hostu, nego shop veže na domenu preko Traefik labela i automatski ishoduje Let's Encrypt certifikat.

Potrebno je u `.env` postaviti dodatnu varijablu `OC_DOMAIN` (npr. `oc.epicea.hr`), te po želji jače lozinke:

```bash
docker compose -f docker-compose.prod.yml up -d --build
```

## Napomena

Ovo je demo/development postavka (root/admin lozinke su iz `.env` u plain textu) — nije namijenjena za produkciju bez dodatnog hardeninga (jače lozinke, zaključavanje admin panela, itd.).
