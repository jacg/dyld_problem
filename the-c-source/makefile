all:
	$(CXX) -fpic -c -O2 -pg $(WORKDIR)/the_C_source_file.cc  -o $(WORKDIR)/the_object_file.o
	$(CXX) -shared -o       $(WORKDIR)/libTheCLibrary.so        $(WORKDIR)/the_object_file.o
