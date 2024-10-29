# Sector7g

This is a stupid application inspired by "Days since last accident" signs seen in movies and on television.
The idea was mostly to teach myself some Elixir/Phoenix, and how to ship it in a container. 
And I was successful in that. 
Maybe you can have fun with it.

### Install
```
helm install sector7g oci://ghcr.io/hermannolafs/charts/sector7g --set 'persistence.enabled=true'
```

### Dev
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
