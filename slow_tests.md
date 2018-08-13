# Slow Tests on ruby

1. Use spring preloader to speed up the boot time.
2. Don't do more work that you need on the setup, instead of using create or build with factory girl, use `build_stubbed`
3. In cases where you only need an attribute of an object, you can use double ex `user = instance_double(User, should_be_billed?: true)`
4. Try to test close to the source that you want to test, like separate views tests from the feature tests.
