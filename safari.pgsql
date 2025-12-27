DROP TABLE IF EXISTS public.paiement;
DROP TABLE IF EXISTS public.ticket;
DROP TABLE IF EXISTS public.trajet;
DROP TABLE IF EXISTS public.terminus;
DROP VIEW IF EXISTS public.profil;


-- CREE LA TABLE profils qui contiendra les profils utilisateurs
CREATE TABLE IF NOT EXISTS public.profils (
  id uuid PRIMARY KEY REFERENCES auth.users(id),
  email TEXT,
  nom TEXT,
  adresse TEXT,
  photo_url TEXT -- contient le lien vers l'image stocké dans un bucket
);

-- CREE LA TABLE terminus qui représente le nom des villes de départ et d'arrivée.
CREATE TABLE IF NOT EXISTS public.terminus (
  nom TEXT PRIMARY KEY
);

-- CREE LA TABLE trajet qui représente un trajet pour lequel l'utilisateur peut reserver son ticket.
CREATE TABLE IF NOT EXISTS public.trajets (
   id SERIAL PRIMARY KEY,
   depart TEXT REFERENCES public.terminus(nom),
   arrivee TEXT REFERENCES public.terminus(nom),
   prix float default 0,
   heure_depart TIME WITHOUT TIME ZONE NOT NULL
);

-- CREE LA TABLE tickets.
CREATE TABLE IF NOT EXISTS public.tickets (
   id SERIAL PRIMARY KEY,
   profil_id uuid REFERENCES public.profils(id),
   trajet_id integer REFERENCES public.trajets(id),
   nom TEXT,
   date_achat timestamp default now()
);

-- CREE LA TABLE paiement qui contient les paiments efféctués par le client pour l'achat des tickets.
CREATE TABLE IF NOT EXISTS public.paiements (
   id SERIAL PRIMARY KEY,
   ticket_id integer REFERENCES public.tickets(id),
   montant float,
   date_paiement timestamp default now()
);

-- insère un nouveaud profil dans public.profils lors de l'enregistrement d'un nouvel utilisateur
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profils(id,email)
  values (new.id,new.email); 
  return new;
end;
$$;

-- trigger the function every time a user is created
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Mot de passe projet
-- Safari@04Andre -- monoton
