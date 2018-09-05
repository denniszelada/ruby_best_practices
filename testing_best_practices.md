# Test best practices
## First follow the Four-Phase Pattern:
1. Setup
2. Exercise
3. Verify
4. Teardown

```ruby
feature "A user exports a CSV", skip: true do
  scenario "it displays a link to download the csv" do
    # Setup
    form = create(:form)
    create(:submission, form: form)
    
    # Exercise
    export_csv(form)
    
    # Verify
    expect(page).to have_link(I18n.t("data.show.download"))
  end
end
```

## Second make the issues clear

## Three, eliminate the mistery guest
> The problem is that's not really clear where it's coming, unless you open another file.
> And as the test grows you need to do more scrolling or even in some cases you might be thinking in overwriting the subject.

```ruby
# Mistery guest example
describe "#first_name" do 
  it "splits the full name on a space and returns the first part" do
    user = build_stubbed(:user)
    
    name = user.first_name
    
    expect(name).to eq "John"
  end
end
```
> Instead we can use something like this
```ruby
# Mistery guest example
describe "#first_name" do 
  it "splits the full name on a space and returns the first part" do
    user = build_stubbed(:user, name: "John Smith")
    
    name = user.first_name
    
    expect(name).to eq "John"
  end
end
```

## Four if you use FactoryGirl use traits

## Five allways make everything explicit.

## Six Don't test private methods, but pay attention if you want to test those methods to extract a class.

## Seven Make tests boring, by not including fuzzy words.

