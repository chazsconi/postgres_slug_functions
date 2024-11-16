# PostgreSQL functions for generating slugs

Functions for generating short, unique, difficult to guess alphanumeric ids that can be used as an identifier in a URL, 
for example for a link to a video call or references to shortened URLs, e.g. 

`https://my-url-shortner/12a7x5r3yz8`.


The requirement for these slugs is that they should be:
1. Short
2. Unique
3. Not easily guessable - the user should not be able to just increment the value and get another valid slug.

## Blog post

There is more detailed information about how this works in this [blog post](https://chazsconi.github.io/2024/11/16/generating-slugs-in-postgres.html).

## To use

1. Create the functions in your DB by runnning the SQL in `functions.sql`.

2. Generate a sequence:

    ```sql
    CREATE SEQUENCE slug_sequence START 1;
    ```

3. Create the table which needs the slugs, for example:

    ```sql
    CREATE TABLE shortened_urls (
        id integer primary key generated always as identity,
        slug varchar(10) DEFAULT generate_slug(nextval('slug_sequence')::int),
        original_url varchar(255)
    );
    ```

Now when we insert a new row, our slug is automatically generated:

```sql
insert into shortened_urls (original_url) values ('https://foo.com/some-long-path');
insert into shortened_urls (original_url) values ('https://bar.com/some-even-longer-path');
```

Checking the results:

```sql
select * from shortened_urls;
```

|id|slug|original_url|
|--|----|------------|
|1|``fwugnmhm7o``|``https://foo.com/some-long-path``|
|2|``wu4dhepl2n``|``https://bar.com/some-even-longer-path``|


Now we can write our app that allows users to access URLs with a short slug, e.g. 

``https://my-url-shortner/fwugnmhm7o``