requires 'perl', '5.010001';

requires 'Test::Power::Core';
requires 'Test::Deep';
requires 'Scope::Guard';
requires 'Module::Spy', '0.03';
requires 'Term::Encoding';
requires 'Module::Load';
requires 'Try::Tiny';
requires 'Moo';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

