requires 'perl', '5.010001';
requires 'Class::Accessor::Lite', 0.05;
requires 'Test::Power::Core';
requires 'Test::Deep';
requires 'Scope::Guard';
requires 'Module::Spy';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

