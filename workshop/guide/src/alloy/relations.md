# Relations

Relations are ubiquitous and the bread and butter of modeling. In this chapter
we take a particular view of relations. This will be one of the foundational
pillars that Alloy is build upon.

## What are relations?

A [recipe](https://en.wikipedia.org/wiki/Recipe) is, among other things, a

> set of directions with a list of ingredients for making or preparing
> something.

A recipe _relates_ food items, such as flour, water, sugar, certain spices and
chocolate chips, with a dish, for example that of a cookie.

**EXERCISE**: Take some of your favorite dishes, pick a recipes for them and
lists some of its ingredients.

So, ingredients is a relation between food items and a recipe. Given a food
item and a recipe, one can determine if the food item is an ingredient of
the recipe.

Let's introduce some notation. In order to indicate that a food item _f_ is an
ingredient to recipe _r_, we use the notation that the ordered tuple _(f, r)_
is an element of a set _I_, for the ingredient relation.

For example because _flour_ is an ingredient for the _cookie_ recipe, the
ingredient relation _I_ contains the the tuple _(flour, cookie)_.

**EXERCISE**: You have listed the ingredients of some recipes in an earlier
exercise. Using the new notation, summarize the information of that exercise.

## Summary

> A _relation_ is a set of ordered tuples.
