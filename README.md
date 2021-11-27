# Spack Build Cache

Have you ever wanted to easily create a build cache, but you aren't so keen about
dishing over your credit card to AWS or GCP? Me too! This is a spack build cache
that is entirely powered by GitHub. That means that packages are built and then
served via GitHub workflows, packages, and pages. It's powered by 
[vsoch/spack-package-action](https://github.com/vsoch/spack-package-action).

## How does it work?

We can use the [vsoch/spack-package-action](https://github.com/vsoch/spack-package-action)
to create two workflows:

 - [manual-build-cache.yaml](.github/workflows/manual-build-cache.yaml): A manally triggered build for a specific package.
 - [build-cache.yaml](.github/workflows/build-cache.yaml): A scheduled job to run builds for the build cache.

For each workflow, spack is installed, and then a build cache is created for some packages of choice.
For the manual trigger, this means a package (or more general, spec that can be built in actions) that you
desire is built. For the scheduled trigger, we randomly select 25 packages from the [spack packages site](https://spack.github.io/packages)
and do the same. In both cases, your repository that triggers the build becomes home to the cache.
It will not only serve the binaries for spack in the Packages tab, but also will serve it's own
RESTful API for spack to interact with. It comes down to the magic of GitHub pages, and the
site will be generated for you on the first run.

## How do I set one up?

The easiest thing to do is to use the site as a template, so you will want to:

1. Fork it to your username
2. Git clone to your workstation
3. `rm -rf docs/` as this will contain someone else's package cache
4. **Importantly** create a personal access token (PAT) and save to `DEPLOY_USER` and `DEPLOY_TOKEN` in your repository secrets. If you change these names, make sure to update the workflow files.
5. Double check that the workflow triggers are what you want
6. Push to your repository and start building!
7. After build, Make sure that url, baseurl, and other metadata is correctly set in the _config.yaml. E.g., for this site we have a custom domain and set url to autamus.io!

If you have any questions, please [don't hesitate to open an issue](https://github.com/autamus/spack-build-cache/issues).
If you have a critique or suggestion for the build cache website or the actions otherwise, please
[open an issue at vsoch's action repository](https://github.com/vsoch/spack-package-action).

## Frequently Asked Questions

> Why should I care?

Build caches have historically been challenging because you need to pay money to a cloud vendor for
storage, and then do all the setup. Researchers and research software engineers are much more comfortable with GitHub,
and (unless we abuse it, don't do that) it should remain free, so an alternative solution to try (I believe) is 
to host a build cache entirely there.

> How does this integrate with spack?

It doesn't yet, but given how a mirror is just a namespaced URL, @vsoch will be adding a ghcr.io endpoint.
The magic comes down to the fact that this endpoint serves it's own API, and in JSON to boot. The *spec.json
files that are alongside the package artifacts are served from here, and the packages will be easily retrieved
with the oras client, which @vsoch has already added as a package we can bootstrap.

> What about package metadata?

Since GitHub packages is using an OCI registry, we have the opportunity to better label our packages
with metadata! @vsoch hasn't done this yet but will explore it.

> What about different architectures?

GitHub can technically do builds using qemu for different arches, but @vsoch has found this buggy or inconsistent at best,
so for the time being we are just using the native GitHub action runns.

> What about compilers?

Interestingly, GitHub runners have quite a few choices! I haven't tried this yet, but I suspect we could add
a compiler variable or selection into the mix. [Let us know](https://github.com/autamus/spack-build-cache/issues) if you have ideas or want to help.

> What about build errors?

You'll likely see a lot of build errors if you randomly select packages (I did). If you find an error and 
want to report is, you can [do that here](https://github.com/spack/spack/issues) and link to the run for more details.

> Can the build cache use itself?

Eventually (hopefully) yes! That would speed things up a bit. :)

> What are some concerns I have?

If there are too many builds at once, there could be an issue syncing git (e.g., we pull and then push) but it's fairly rare.
I'm also worried about the number of entries in the cache getting too big for GitHub pages - when this happens we can
run a workflow to do the site build, and when that no longer works we can remove redundant (older) entries from the build
cache. When there's a will there's a way!
