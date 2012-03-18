function sized_print(width,height,varargin)
pos=get(gcf,'Position');
set(gcf,'PaperPositionMode','auto')
pos(3)=width-1;
pos(4)=height;
set(gcf,'Position',pos);
print('-r0',varargin{:});
end
