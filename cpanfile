requires 'perl', '5.010001';

recommends 'Test::Power::Core', '0.13';
requires 'Test::Deep';
requires 'Scope::Guard';
requires 'Module::Spy', '0.03';
requires 'Term::Encoding';
requires 'Module::Load';
requires 'Try::Tiny';
requires 'Moo';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Requires';
    requires 'Text::Diff';
};

