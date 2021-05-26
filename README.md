# **Push-swap tester**

This is a simple but efficient tester for the 42 push-swap project.

The project asks the student to write a program that can sort a given stack with the _least_ number of actions possible.

## Included
- Simple ruby program to generate stacks
- Homemade checker program
- push-swap tester

## Usage tester
1. Clone the project:<br/>In your terminal, preferably in the same directory as your project run:<br/>`git clone git@github.com:jlsrvr/PUSH-SWAP-TESTER.git`
2. Move into the cloned directory:<br/>`cd PUSH-SWAP_TESTER`
3. Generate the configuration file:<br/>`./run_specs.sh`
4. Edit the generated <my_config.sh> by adding the path to your project
5. Run the tester<br/>`./run_specs.sh`
6. Stacks that fail can either be found in the output or in the specified files.

### Covered:
- Basic tests for error cases.
- Behaviour for a sorted stack of size up to 100.
- Uses the given max number of actions to determine if algorithm is fast enough (see configuration file).
- For stacks of size 5, 100, and 500 performs an average on randomly generated stacks (see configuration file to change number of runs).

## Usage stack generator
At the root of the tester run this command in your terminal:<br/>`ruby srcs/stack_generator.rb`

Follow the on screen prompts.

