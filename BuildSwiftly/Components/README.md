#  Components

## Overview

This folder contains generic component APIs to be called by client programs and can easily be integrated with the client UI. Components in this folder should be simple, readable, and easy to expand upon without needing to modify much of the existing codebase. Functionality of each component should be simple enough to explain in a single word or expression, and names should be representative of the functionality of the code. Components can reference other components when necessary, but should not fully depend on other components. For example, we have both a `Search` and a `DataStore` component. In order to search our data efficiently using `Search`, in `DataStore`  we might want to store the data separately using some database and another third-party search engine. We call `Search.store(data: data)` in our `DataStore` component, and the client calls `Search.search(query: query)` to search the data stored. Though the `Search` component was referenced by the `DataStore`, removing this reference will not hinder `DataStore`'s ability to sucessfully perform its designed task. Similary, by removing the `DataStore` reference in `Search`, `Search` should still be able to effectively search and store data as it was design to do.

## Contributing

There is no particular structure that is required, however, I *require* any new components to be placed in a separate folder and highly encourage you to add an *optional* README to the root if necessary.

## Components

**More components coming soon. This document show be updated when necessary.**

* Authentication - ***Firestore***: This folder contains components for authenticating, verifiying, and referencing a user and their respective data


