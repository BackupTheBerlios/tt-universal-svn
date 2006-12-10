package gui;
use base 'CGI::Application';


sub setup {
      my $self = shift;
      $self->start_mode('start');
      $self->mode_param('level');
      $self->run_modes(
              'start' => 'start_form',
#              'search' => 'do_more_stuff',
#              'result1' => 'do_something_else'
      );
}
sub start_form {
print CGI::header();
# print "gui start\n"
}
#sub search { print "gui search\n" }
#sub result1 { print "gui result1\n" }


1;